package com.example.sa_aulas

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.activity.viewModels
import androidx.lifecycle.Observer

class MainActivity : ComponentActivity() {

    private val aViewModel: AccelerometerViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // get the sensor manager
        val sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val accelerometerSensorListener = AccelerometerSensorListener()

        val accelerometerObserver = Observer<AccelerometerData> { accSample ->
            findViewById<TextView>(R.id.textView4).text = accSample.valueX.toString()
            findViewById<TextView>(R.id.textView5).text = accSample.valueY.toString()
            findViewById<TextView>(R.id.textView6).text = accSample.valueZ.toString()
        }

        findViewById<Button>(R.id.register_button).setOnClickListener{
            Log.d("BUTTON","User clicked the register button.")
            // get the accelerometer sensor
            val mAccelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
            // if the smartphone has this sensor
            if (mAccelerometer != null){
                accelerometerSensorListener.setSensorManager(sensorManager,accelerometerObserver)
                sensorManager.registerListener(accelerometerSensorListener, mAccelerometer,
                    SensorManager.SENSOR_DELAY_NORMAL)
            }
        }

        findViewById<Button>(R.id.unregister_button).setOnClickListener {
            Log.d("BUTTON", "User clicked the unregister button.")
            sensorManager.unregisterListener(accelerometerSensorListener)
        }

    }
}
