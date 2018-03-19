package com.tpms.maps.tpmsapp;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import android.content.Intent;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.cardiomood.android.controls.gauge.SpeedometerGauge;

import java.io.IOException;
import java.io.InputStream;
import java.util.Set;
import java.util.UUID;

/**
 * Created by Antoniu
 */

public class MainTPMS extends AppCompatActivity {

    private static String webURL = "http://www.bridgestonetire.com/tread-and-trend/drivers-ed/tire-pressure-monitoring-system-how-tpms-works";
    private SpeedometerGauge speedometer;
    BluetoothAdapter mBluetoothAdapter;
    BluetoothDevice mDevice;
    ConnectThread mConnectThread;
    ConnectedThread mConnectedThread;
    Handler mHandler;
    int speed, leftTyre, rightTyre;
    TextView LTyreText, RTyreText;
    ImageView leftTyreImage, rightTyreImage;
    boolean flagLTflat = false, flagRTflat = false;
    MediaPlayer mAlertLeft, mAlertRight;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main_tpms);
        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        LTyreText = (TextView) findViewById(R.id.leftWarning);
        RTyreText = (TextView) findViewById(R.id.rightWarning);
        leftTyreImage = (ImageView) findViewById(R.id.LeftTyre);
        rightTyreImage = (ImageView) findViewById(R.id.RightTyre);
        mAlertLeft = MediaPlayer.create(this, R.raw.left_tyre_underinflated);
        mAlertRight = MediaPlayer.create(this, R.raw.right_tyre_underinflated);
        speedometer = (SpeedometerGauge) findViewById(R.id.speedometer);
        speedometer.setLabelTextSize(50);
        speedometer.setLabelConverter(new SpeedometerGauge.LabelConverter() {
            @Override
            public String getLabelFor(double progress, double maxProgress) {
                return String.valueOf((int) Math.round(progress));
            }
        });
        speedometer.setMaxSpeed(200);
        speedometer.setMinorTicks(1);
        speedometer.setMajorTickStep(20);
        speedometer.addColoredRange(30, 100, Color.GREEN);
        speedometer.addColoredRange(100, 140, Color.YELLOW);
        speedometer.addColoredRange(140, 220, Color.rgb(255, 125, 0));
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (mBluetoothAdapter == null) {
            // Device does not support Bluetooth
        }
        if (!mBluetoothAdapter.isEnabled()) {
            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableBtIntent, 1);
        } else {
            pairDevices();
        }
        mHandler = new Handler() {
            @Override
            public void handleMessage(Message msg) {
                byte[] writeBuf = (byte[]) msg.obj;
                int begin = (int) msg.arg1;
                int end = (int) msg.arg2;
                switch (msg.what) {
                    case 1:
                        String writeMessage = new String(writeBuf);
                        writeMessage = writeMessage.substring(begin, end);
                        leftTyre = Integer.parseInt(writeMessage.substring(writeMessage.indexOf(";") + 1, writeMessage.indexOf("L")));
                        rightTyre = Integer.parseInt((writeMessage.substring(writeMessage.indexOf("L") + 1, writeMessage.indexOf("R"))));
                        speed = Integer.parseInt(writeMessage.substring(writeMessage.indexOf("R") + 1, writeMessage.length()));
                        speedometer.setSpeed(speed);
                        break;
                }

                if ((rightTyre != 0) && (flagRTflat == false)) {
                    flagRTflat = true;
                    mAlertRight.start();
                    rightTyreImage.setImageResource(R.drawable.tyreflat);
                    RTyreText.setVisibility(View.VISIBLE);
                } else if ((rightTyre == 0) && (flagRTflat == true)) {
                    flagRTflat = false;
                    rightTyreImage.setImageResource(R.drawable.tyreok);
                    RTyreText.setVisibility(View.INVISIBLE);
                }
                if ((leftTyre != 0) && (flagLTflat == false)) {
                    flagLTflat = true;
                    mAlertLeft.start();
                    leftTyreImage.setImageResource(R.drawable.tyreflat);
                    LTyreText.setVisibility(View.VISIBLE);
                } else if ((leftTyre == 0) && (flagLTflat == true)) {
                    flagLTflat = false;
                    leftTyreImage.setImageResource(R.drawable.tyreok);
                    LTyreText.setVisibility(View.INVISIBLE);
                }
            }
        };
    }

    public void pairDevices() {
        Set<BluetoothDevice> pairedDevices = mBluetoothAdapter.getBondedDevices();
        if (pairedDevices.size() > 0) {
            for (BluetoothDevice device : pairedDevices) {
                mDevice = device;
            }
            mConnectThread = new ConnectThread(mDevice);
            mConnectThread.start();
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode == RESULT_OK) {
            pairDevices();
        } else {
            finish();
        }
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main_tpms, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        //noinspection SimplifiableIfStatement
        switch (id) {
            case R.id.action_about:
                Intent intentAbout = new Intent(this, AboutTPMS.class);
                startActivity(intentAbout);
                return true;
            case R.id.action_info:
                Intent webIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(webURL));
                if (webIntent.resolveActivity(getPackageManager()) != null) {
                    startActivity(webIntent);
                }
                return true;
            case R.id.action_contact:
                String[] email = {"antoniu.miclaus@gmail.com"};
                Intent contactIntent = new Intent(Intent.ACTION_SENDTO);
                contactIntent.setData(Uri.parse("mailto:"));
                contactIntent.putExtra(Intent.EXTRA_EMAIL, email);
                contactIntent.putExtra(Intent.EXTRA_SUBJECT, "Information Request iTPMS App");
                if (contactIntent.resolveActivity(getPackageManager()) != null) {
                    startActivity(contactIntent);
                }
                return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public void buttonClickHandler(View view) {
        Intent intent = new Intent(this, MapsTPMS.class);
        startActivity(intent);
    }

    private class ConnectThread extends Thread {
        private final BluetoothSocket mmSocket;
        private final BluetoothDevice mmDevice;
        private final UUID MY_UUID = UUID.fromString("00001101-0000-1000-8000-00805f9b34fb");

        public ConnectThread(BluetoothDevice device) {
            BluetoothSocket tmp = null;
            mmDevice = device;
            try {
                tmp = device.createRfcommSocketToServiceRecord(MY_UUID);
            } catch (IOException e) {
            }
            mmSocket = tmp;
        }

        public void run() {
            mBluetoothAdapter.cancelDiscovery();
            try {
                mmSocket.connect();
            } catch (IOException connectException) {
                try {
                    mmSocket.close();
                } catch (IOException closeException) {
                }
                return;
            }
            mConnectedThread = new ConnectedThread(mmSocket);
            mConnectedThread.start();
        }

        public void cancel() {
            try {
                mmSocket.close();
            } catch (IOException e) {
            }
        }
    }

    private class ConnectedThread extends Thread {
        private final BluetoothSocket mmSocket;
        private final InputStream mmInStream;

        public ConnectedThread(BluetoothSocket socket) {
            mmSocket = socket;
            InputStream tmpIn = null;
            try {
                tmpIn = socket.getInputStream();
            } catch (IOException e) {
                e.getStackTrace();
            }
            mmInStream = tmpIn;
        }

        public void run() {
            int end, start = 0, readBytes = 0;
            byte[] dataBuffer = new byte[1024];
            while (true) {
                try {
                    readBytes += mmInStream.read(dataBuffer, readBytes, dataBuffer.length - readBytes);
                    for (int i = start; i < readBytes; i++) {
                        if (dataBuffer[i] == "S".getBytes()[0]) {
                            end = i;
                            mHandler.obtainMessage(1, start, end, dataBuffer).sendToTarget();
                            start = i + 1;
                            if (i == readBytes - 1) {
                                readBytes = 0;
                                start = 0;
                            }
                        }
                    }
                } catch (IOException e) {
                    break;
                }
            }
        }

        public void cancel() {
            try {
                mmSocket.close();
            } catch (IOException e) {
            }
        }
    }
}
