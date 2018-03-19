package com.tpms.maps.tpmsapp;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.pm.PackageManager;
import android.location.Location;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.FragmentActivity;
import android.util.Log;
import android.widget.Toast;

import com.google.android.gms.appindexing.Action;
import com.google.android.gms.appindexing.AppIndex;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationListener;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.places.Places;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.UiSettings;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.gms.maps.model.Polyline;
import com.google.android.gms.maps.model.PolylineOptions;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Antoniu
 */

public class MapsTPMS extends FragmentActivity implements
        GoogleApiClient.ConnectionCallbacks,
        GoogleApiClient.OnConnectionFailedListener,
        LocationListener {

    boolean flag_permission, flag_camera, flag_connection = false;
    public static final String TAG = MapsTPMS.class.getSimpleName();
    public static final int MAX_GAS_STATIONS = 5;
    Marker marker_car = null;
    List<Marker> marker_gas;
    UiSettings myUiSettings;
    private final static float ZOOM_LEVEL = 13;
    Handler handler;
    Polyline polyline;

    private final static int CONNECTION_FAILURE_RESOLUTION_REQUEST = 9000;
    private static final int MY_PERMISSIONS_REQUEST_MAPS_RECEIVE = 0;

    private GoogleMap mMap;

    private GoogleApiClient mGoogleApiClient;
    private LocationRequest mLocationRequest;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        marker_gas = new ArrayList<>(5);
        flag_permission = false;
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_maps_tpms);
        setUpMapIfNeeded();
        myUiSettings = mMap.getUiSettings();
        myUiSettings.setCompassEnabled(true);
        myUiSettings.setZoomControlsEnabled(true);

        mGoogleApiClient = new GoogleApiClient.Builder(this)
                .addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .addApi(LocationServices.API)
                .addApi(Places.GEO_DATA_API)
                .enableAutoManage(this, this)
                .addApi(Places.PLACE_DETECTION_API)
                .addApi(AppIndex.API).build();

        // Create the LocationRequest object
        mLocationRequest = LocationRequest.create()
                .setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY)
                .setInterval(5 * 1000)
                .setFastestInterval(1 * 1000);
        handler = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                ((MessageContent) msg.obj).apply();
            }
        };
        mMap.setOnMarkerClickListener(new GoogleMap.OnMarkerClickListener() {

            @Override
            public boolean onMarkerClick(Marker arg) {
                if (arg.getTitle().equals(marker_car.getTitle())) { // if marker source is clicked
                    Toast.makeText(MapsTPMS.this, arg.getTitle(), Toast.LENGTH_SHORT).show();// display toast
                    arg.showInfoWindow();
                } else {
                    new GMapDirection(marker_car.getPosition(), arg.getPosition(), "driving", MapsTPMS.this).start();
                }
                return true;
            }

        });
    }

    public Handler getHandler() {
        return handler;
    }

    @Override
    protected void onResume() {
        super.onResume();
        setUpMapIfNeeded();
        mGoogleApiClient.connect();
    }

    @Override
    protected void onPause() {
        super.onPause();

        if (mGoogleApiClient.isConnected()) {
            LocationServices.FusedLocationApi.removeLocationUpdates(mGoogleApiClient, this);
            mGoogleApiClient.disconnect();
        }
    }

    private void setUpMapIfNeeded() {
        // Do a null check to confirm that we have not already instantiated the map.
        if (mMap == null) {
            // Try to obtain the map from the SupportMapFragment.
            mMap = ((SupportMapFragment) getSupportFragmentManager().findFragmentById(R.id.map))
                    .getMap();
            // Check if we were successful in obtaining the map.
            if (mMap != null) {
                setUpMap();
            }
        }
    }

    private void setUpMap() {
    }

    private void handleNewLocation(Location location) {

        double currentLatitude = location.getLatitude();
        double currentLongitude = location.getLongitude();

        LatLng latLng_car = new LatLng(currentLatitude, currentLongitude);

        if (marker_car == null) {
            MarkerOptions options_1 = new MarkerOptions()
                    .position(latLng_car)
                    .anchor(0.5f,0.5f)
                    .title("My Location!")
                    .icon(BitmapDescriptorFactory.fromResource(R.drawable.car_marker));
            marker_car = mMap.addMarker(options_1);
            marker_car.showInfoWindow();
        } else {
            marker_car.setPosition(latLng_car);
        }

        if (flag_camera == false) {
            mMap.moveCamera(CameraUpdateFactory.newLatLngZoom(latLng_car, ZOOM_LEVEL));
            flag_camera = true;
        }
        if (isNetworkAvailable()) {
            flag_connection = false;
            new GasLocRequest(location, "gas_station", this).start();
        } else if (flag_connection == false) {
            flag_connection = true;
            Toast.makeText(this, "No Internet Connection",
                    Toast.LENGTH_LONG).show();
        } else {
            return;
        }
    }

    @Override
    public void onConnected(Bundle bundle) {
        if (flag_permission == true) {
            return;
        } else {
            flag_permission = true;
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                // TODO: Consider calling
                ActivityCompat.requestPermissions(this,
                        new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                        MY_PERMISSIONS_REQUEST_MAPS_RECEIVE);
            } else {
                LocationServices.FusedLocationApi.requestLocationUpdates(mGoogleApiClient, mLocationRequest, this);
            }
        }

    }

    @Override
    public void onConnectionSuspended(int i) {

    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {

        if (connectionResult.hasResolution()) {
            try {
                connectionResult.startResolutionForResult(this, CONNECTION_FAILURE_RESOLUTION_REQUEST);
            } catch (IntentSender.SendIntentException e) {
                e.printStackTrace();
            }
        } else {
            Log.i(TAG, "Location services connection failed with code " + connectionResult.getErrorCode());
        }
    }

    @Override
    public void onLocationChanged(Location location) {

        handleNewLocation(location);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {

            Intent intent = new Intent(this, MainTPMS.class);
            startActivity(intent);
        } else {
            flag_permission = false;
        }

    }


    @Override
    public void onStart() {
        super.onStart();
        flag_permission = false;
        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        mGoogleApiClient.connect();
        Action viewAction = Action.newAction(
                Action.TYPE_VIEW, // TODO: choose an action type.
                "MapsTPMS Page", // TODO: Define a title for the content shown.
                // TODO: If you have web page content that matches this app activity's content,
                // make sure this auto-generated web page URL is correct.
                // Otherwise, set the URL to null.
                Uri.parse("http://host/path"),
                // TODO: Make sure this auto-generated app URL is correct.
                Uri.parse("android-app://com.tpms.maps.tpmsapp/http/host/path")
        );
        AppIndex.AppIndexApi.start(mGoogleApiClient, viewAction);
    }

    @Override
    public void onStop() {
        super.onStop();

        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        Action viewAction = Action.newAction(
                Action.TYPE_VIEW, // TODO: choose an action type.
                "MapsTPMS Page", // TODO: Define a title for the content shown.
                // TODO: If you have web page content that matches this app activity's content,
                // make sure this auto-generated web page URL is correct.
                // Otherwise, set the URL to null.
                Uri.parse("http://host/path"),
                // TODO: Make sure this auto-generated app URL is correct.
                Uri.parse("android-app://com.tpms.maps.tpmsapp/http/host/path")
        );
        AppIndex.AppIndexApi.end(mGoogleApiClient, viewAction);
        mGoogleApiClient.disconnect();
    }

    private boolean isNetworkAvailable() {
        ConnectivityManager connectivityManager
                = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo activeNetworkInfo = connectivityManager.getActiveNetworkInfo();
        return activeNetworkInfo != null && activeNetworkInfo.isConnected();
    }

    public abstract class MessageContent {
        abstract void apply();
    }

    public class MessageDirection extends MessageContent {
        GasDirection gasDirection;

        MessageDirection(GasDirection gasDirections) {
            this.gasDirection = gasDirections;
        }

        @Override
        void apply() {
            if (polyline != null) {
                polyline.remove();
            }
            PolylineOptions polylineOptions = new PolylineOptions().width(12).color(R.color.colorDirection).geodesic(true);
            for (int j = 0; j < gasDirection.getRoute().size(); j++) {
                LatLng point = gasDirection.getRoute().get(j);
                polylineOptions.add(point);
            }
            polyline = mMap.addPolyline(polylineOptions);
            for(Marker m: marker_gas){
                if(m.getPosition().equals(gasDirection.getLastLocation())){
                    m.setSnippet(gasDirection.getDistance()+"("+ gasDirection.getDuration()+")");
                    m.showInfoWindow();
                }
            }
        }

    }

    public class MessageError extends MessageContent {
        String msg;

        MessageError(String msg) {
            this.msg = msg;
        }

        @Override
        void apply() {
            Toast.makeText(MapsTPMS.this, "No Internet Connection",
                    Toast.LENGTH_LONG).show();
        }
    }

    public class MessageLocation extends MessageContent {
        List<GasLocation> gasLocations;

        MessageLocation(List<GasLocation> gasLocations) {
            this.gasLocations = gasLocations;
        }

        @Override
        void apply() {
            int i;
            MarkerOptions options_2 = new MarkerOptions()
                    .icon(BitmapDescriptorFactory.fromResource(R.drawable.gas_marker));
            for (i = 0; i < gasLocations.size() && i < MAX_GAS_STATIONS; ++i) {
                LatLng latLng_station = new LatLng(gasLocations.get(i).getLatitude(), gasLocations.get(i).getLongitude());
                options_2.position(latLng_station).title(gasLocations.get(i).getName());
                if (i >= marker_gas.size()) {
                    marker_gas.add(mMap.addMarker(options_2));
                } else {
                    marker_gas.get(i).setPosition(latLng_station);
                    marker_gas.get(i).setVisible(true);
                }
            }
            for (; i < MAX_GAS_STATIONS && i < marker_gas.size(); ++i) {
                marker_gas.get(i).setVisible(false);
            }
        }
    }
}
