package com.fiveq.ffci.ui.components

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.unit.dp
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import kotlinx.coroutines.delay

private const val TAG = "AudioPlayer"

@Composable
fun AudioPlayer(
    url: String,
    title: String? = null,
    artist: String? = null,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current

    var isPlaying by remember(url) { mutableStateOf(false) }
    var duration by remember(url) { mutableLongStateOf(0L) }
    var position by remember(url) { mutableLongStateOf(0L) }
    var isLoading by remember(url) { mutableStateOf(true) }

    val player = remember(url) {
        ExoPlayer.Builder(context).build().apply {
            val mediaItem = MediaItem.fromUri(url)
            setMediaItem(mediaItem)
            prepare()
            Log.d(TAG, "ExoPlayer created with URL: $url")
        }
    }

    // Listen for player state changes
    DisposableEffect(player) {
        val listener = object : Player.Listener {
            override fun onPlaybackStateChanged(state: Int) {
                Log.d(TAG, "Playback state changed: $state")
                when (state) {
                    Player.STATE_READY -> {
                        isLoading = false
                        duration = player.safeDuration()
                        position = player.currentPosition.coerceIn(0L, duration)
                        Log.d(TAG, "Player ready, duration: $duration ms")
                    }
                    Player.STATE_BUFFERING -> {
                        isLoading = true
                    }
                    Player.STATE_ENDED -> {
                        isPlaying = false
                        player.seekTo(0)
                    }
                    else -> {}
                }
            }

            override fun onIsPlayingChanged(playing: Boolean) {
                isPlaying = playing
                Log.d(TAG, "Is playing changed: $playing")
            }
        }

        player.addListener(listener)

        onDispose {
            Log.d(TAG, "Disposing ExoPlayer")
            player.removeListener(listener)
            player.release()
        }
    }

    // Keep progress synchronized even before playback starts so the slider never
    // renders with stale or out-of-range values while media metadata settles.
    LaunchedEffect(player) {
        while (true) {
            duration = player.safeDuration()
            position = if (duration > 0) {
                player.currentPosition.coerceIn(0L, duration)
            } else {
                0L
            }
            delay(500)
        }
    }

    Surface(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = 16.dp),
        shape = RoundedCornerShape(16.dp),
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f),
        tonalElevation = 2.dp
    ) {
        Column(
            modifier = Modifier.padding(20.dp)
        ) {
            // Title and Artist
            if (title != null) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onSurface
                )
            }
            if (artist != null) {
                Text(
                    text = artist,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            AudioSeekBar(
                position = position,
                duration = duration,
                onSeek = { newPosition ->
                    position = newPosition
                    player.seekTo(newPosition)
                },
                modifier = Modifier.fillMaxWidth()
            )

            // Time Display
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = formatTime(position),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = formatTime(duration),
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Play/Pause Button
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.Center
            ) {
                IconButton(
                    onClick = {
                        if (isPlaying) {
                            player.pause()
                        } else {
                            player.play()
                        }
                    },
                    modifier = Modifier
                        .size(64.dp)
                        .clip(CircleShape)
                        .background(MaterialTheme.colorScheme.primary)
                ) {
                    Icon(
                        imageVector = if (isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                        contentDescription = if (isPlaying) "Pause" else "Play",
                        modifier = Modifier.size(36.dp),
                        tint = MaterialTheme.colorScheme.onPrimary
                    )
                }
            }
        }
    }
}

@Composable
private fun AudioSeekBar(
    position: Long,
    duration: Long,
    onSeek: (Long) -> Unit,
    modifier: Modifier = Modifier
) {
    val primary = MaterialTheme.colorScheme.primary
    val inactive = primary.copy(alpha = 0.24f)
    val fraction = if (duration > 0) {
        position.coerceIn(0L, duration).toFloat() / duration.toFloat()
    } else {
        0f
    }

    fun seekFromX(x: Float, width: Int) {
        if (duration <= 0 || width <= 0) return
        val nextFraction = (x / width.toFloat()).coerceIn(0f, 1f)
        onSeek((nextFraction * duration).toLong().coerceIn(0L, duration))
    }

    Canvas(
        modifier = modifier
            .height(36.dp)
            .pointerInput(duration) {
                detectTapGestures { offset ->
                    seekFromX(offset.x, size.width)
                }
            }
            .pointerInput(duration) {
                detectDragGestures { change, _ ->
                    seekFromX(change.position.x, size.width)
                }
            }
    ) {
        val thumbRadius = 8.dp.toPx()
        val trackHeight = 8.dp.toPx()
        val trackStart = thumbRadius
        val trackWidth = size.width - thumbRadius * 2
        val centerY = size.height / 2f
        val activeWidth = trackWidth * fraction

        drawRoundedTrack(
            color = inactive,
            startX = trackStart,
            centerY = centerY,
            width = trackWidth,
            height = trackHeight
        )

        if (activeWidth > 0f) {
            drawRoundedTrack(
                color = primary,
                startX = trackStart,
                centerY = centerY,
                width = activeWidth,
                height = trackHeight
            )
        }

        drawCircle(
            color = primary,
            radius = thumbRadius,
            center = Offset(trackStart + activeWidth, centerY)
        )
    }
}

private fun androidx.compose.ui.graphics.drawscope.DrawScope.drawRoundedTrack(
    color: Color,
    startX: Float,
    centerY: Float,
    width: Float,
    height: Float
) {
    drawRoundRect(
        color = color,
        topLeft = Offset(startX, centerY - height / 2f),
        size = Size(width.coerceAtLeast(0f), height),
        cornerRadius = CornerRadius(height / 2f, height / 2f)
    )
}

private fun Player.safeDuration(): Long {
    return duration
        .takeIf { it != C.TIME_UNSET && it > 0L }
        ?: 0L
}

private fun formatTime(milliseconds: Long): String {
    val totalSeconds = milliseconds / 1000
    val minutes = totalSeconds / 60
    val seconds = totalSeconds % 60
    return "%d:%02d".format(minutes, seconds)
}
