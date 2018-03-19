package com.tpms.maps.tpmsapp;

import com.google.android.gms.maps.model.LatLng;

import java.util.ArrayList;

/**
 * Created by Antoniu
 */

public class GasDirection {
    private ArrayList<LatLng> route;
    private String duration, distance;
    LatLng latLng;

    GasDirection() {
        route = new ArrayList<LatLng>();
    }

    public void setDuration(String duration) {
        this.duration = duration;
    }

    public void setDistance(String distance) {
        this.distance = distance;
    }

    public void addPoly(ArrayList<LatLng> poly) {
        route.addAll(poly);
    }

    public void setLastLocation(LatLng latLng) {
        this.latLng = latLng;
    }

    public String getDuration() {
        return duration;
    }

    public String getDistance() {
        return distance;
    }

    public ArrayList<LatLng> getRoute() {
        return route;
    }

    public LatLng getLastLocation() {
        return latLng;
    }
}
