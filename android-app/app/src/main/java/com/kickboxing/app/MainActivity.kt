package com.kickboxing.app

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.kickboxing.app.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        binding.scanButton.setOnClickListener {
            startActivity(ScannerActivity.newIntent(this))
        }
    }
}
