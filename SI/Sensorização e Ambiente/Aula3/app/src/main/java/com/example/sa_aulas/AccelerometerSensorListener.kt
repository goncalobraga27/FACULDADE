package com.example.sa_aulas

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModel

class AccelerometerSensorListener : SensorEventListener{

    companion object{
        private const val TAG : String = "AccelerometerSensorListener"
    }

    private lateinit var sensorManager: SensorManager
    private lateinit var ourAccelerometerViewModel: AccelerometerViewModel

    fun setSensorManager(sensorMan: SensorManager, aViewModel: Observer<AccelerometerData>){
        sensorManager = sensorMan
        ourAccelerometerViewModel = aViewModel
    }

    override fun onSensorChanged(event: SensorEvent) {
        AccelerometerData.valueX = event.values[0]
        AccelerometerData.valueY = event.values[1]
        AccelerometerData.valueZ = event.values[2]
        AccelerometerData.accuracy = event.accuracy
        //sensorManager.unregisterListener(this)
        //Log.d(TAG,"[Sensor]- X = ${AccelerometerData.valueX}, Y = ${AccelerometerData.valueZ}, Z = ${AccelerometerData.valueZ} ")
        ourAccelerometerViewModel.currentAccelerometerData.value = AccelerometerData
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}