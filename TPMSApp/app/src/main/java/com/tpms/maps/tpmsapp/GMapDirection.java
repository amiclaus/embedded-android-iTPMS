package com.tpms.maps.tpmsapp;

import android.os.Message;

import com.google.android.gms.maps.model.LatLng;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;

/**
 * Created by Antoniu
 */

public class GMapDirection extends Thread {
    private LatLng start, end;
    private String mode;
    private static final String API_KEY_DIRECTION = "AIzaSyAcW3PyN5K_lEujtxhdRKWFpKbdRgyIoes";
    MapsTPMS activity;

    public GMapDirection(LatLng start, LatLng end, String mode, MapsTPMS activity) {
        this.start = start;
        this.end = end;
        this.mode = mode;
        this.activity = activity;
    }

    private String readApiDirection() {
        try {
            URL page = new URL(String.format("https://maps.googleapis.com/maps/api/directions/json?"
                    + "origin=" + start.latitude + "," + start.longitude
                    + "&destination=" + end.latitude + "," + end.longitude
                    + "&mode=" + mode + "&key=" + API_KEY_DIRECTION));
            BufferedReader in = new BufferedReader(new InputStreamReader(page.openStream()));
            StringBuilder str = new StringBuilder();
            String line;
            while ((line = in.readLine()) != null) {
                str.append(line);
            }
            return str.toString();
        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return "";
    }

    private GasDirection obtainedDirection() {
        GasDirection route = new GasDirection();
        route.setLastLocation(end);
        String json = readApiDirection();
        double duration = 0;
        double distance = 0;
        try {
            JSONObject parsed = new JSONObject(json);
            if (parsed.has("routes")) {
                JSONArray routes = parsed.getJSONArray("routes");
                if (routes.length() > 0) {

                    JSONArray legs = routes.getJSONObject(0).getJSONArray("legs");
                    for (int i = 0; i < legs.length(); ++i) {
                        duration += legs.getJSONObject(i).getJSONObject("duration").getDouble("value");
                        distance += legs.getJSONObject(i).getJSONObject("distance").getDouble("value");
                        JSONArray steps = legs.getJSONObject(i).getJSONArray("steps");
                        for (int j = 0; j < steps.length(); ++j) {
                            ArrayList<LatLng> poly = new ArrayList<LatLng>();
                            String polyline = steps.getJSONObject(j).getJSONObject("polyline").getString("points");
                            poly = decodePoly(polyline);
                            route.addPoly(poly);
                        }
                    }

                }
                route.setDuration(Math.round(duration / 60) + "min");
                route.setDistance(String.format("%.1f", (distance / 1000)) + "km");
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return route;
    }

    private ArrayList<LatLng> decodePoly(String encoded) {
        ArrayList<LatLng> poly = new ArrayList<LatLng>();
        int index = 0, len = encoded.length();
        int lat = 0, lng = 0;
        while (index < len) {
            int b, shift = 0, result = 0;
            do {
                b = encoded.charAt(index++) - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20);
            int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
            lat += dlat;
            shift = 0;
            result = 0;
            do {
                b = encoded.charAt(index++) - 63;
                result |= (b & 0x1f) << shift;
                shift += 5;
            } while (b >= 0x20);
            int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
            lng += dlng;

            LatLng position = new LatLng((double) lat / 1E5, (double) lng / 1E5);
            poly.add(position);
        }
        return poly;
    }

    public void run() {
        GasDirection gasDirection = obtainedDirection();
        Message msg = activity.getHandler().obtainMessage();
        msg.obj = activity.new MessageDirection(gasDirection);
        activity.getHandler().sendMessage(msg);
    }
}

