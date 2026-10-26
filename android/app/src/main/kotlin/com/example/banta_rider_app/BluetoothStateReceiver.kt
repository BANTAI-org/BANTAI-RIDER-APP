package com.example.banta_rider_app

import android.bluetooth.BluetoothAdapter
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

class BluetoothStateReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != BluetoothAdapter.ACTION_STATE_CHANGED ||
            intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR) !=
                BluetoothAdapter.STATE_ON
        ) {
            return
        }

        val launchIntent = context.packageManager
            .getLaunchIntentForPackage(context.packageName)
            ?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            ?: return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            launchIntent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
        }
        context.startActivity(launchIntent)
    }
}
