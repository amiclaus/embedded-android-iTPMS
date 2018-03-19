package com.tpms.maps.tpmsapp;

import android.location.Location;
import android.os.Message;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Antoniu
 */

public class GasLocRequest extends Thread {
    private static final String WEB_API_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=%1$s&types=%2$s&location=%3$f,%4$f&rankby=distance";
    private Location myLocation;
    private static final String WEB_API_KEY = "AIzaSyAcW3PyN5K_lEujtxhdRKWFpKbdRgyIoes";
    private String type;
    MapsTPMS activity;

    GasLocRequest(Location myLocation, String type, MapsTPMS activity) {
        this.myLocation = myLocation;
        this.type = type;
        this.activity=activity;
    }
    private String readApi() {
        try {
            URL page = new URL(String.format(WEB_API_URL, WEB_API_KEY, type, myLocation.getLatitude(), myLocation.getLongitude()));
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

    private List<GasLocation> obtainedLocations() {
        List<GasLocation> list = new ArrayList<GasLocation>();
        String json = readApi();
        try {
            JSONObject parsed = new JSONObject(json);
            if (parsed.has("results")) {
                JSONArray result = parsed.getJSONArray("results");

                for (int i = 0; i < result.length(); ++i) {
                    GasLocation gasLocation = new GasLocation();
                    gasLocation.setLatitude(result.getJSONObject(i).getJSONObject("geometry").getJSONObject("location").getDouble("lat"));
                    gasLocation.setLongitude(result.getJSONObject(i).getJSONObject("geometry").getJSONObject("location").getDouble("lng"));
                    gasLocation.setName(result.getJSONObject(i).getString("name"));
                    list.add(gasLocation);
                }
            }
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void run() {
        List<GasLocation> suggestions = obtainedLocations();
        Message msg = activity.getHandler().obtainMessage();
        msg.obj = activity.new MessageLocation(suggestions);
        activity.getHandler().sendMessage(msg);
    }
}
