package com.fiveq.ffci.data.api

import com.squareup.moshi.JsonAdapter
import com.squareup.moshi.JsonQualifier
import com.squareup.moshi.JsonReader
import com.squareup.moshi.JsonWriter
import com.squareup.moshi.Moshi
import com.squareup.moshi.Types
import java.lang.reflect.Type

/**
 * Handles PHP's json_encode() quirk where associative arrays with numeric keys
 * serialize as JSON objects ({"0": {...}, "1": {...}}) instead of arrays ([...]).
 * Apply @FlexibleList to any List field that may receive either format.
 */
@Retention(AnnotationRetention.RUNTIME)
@JsonQualifier
annotation class FlexibleList

class FlexibleListAdapterFactory : JsonAdapter.Factory {
    override fun create(type: Type, annotations: Set<Annotation>, moshi: Moshi): JsonAdapter<*>? {
        annotations.find { it is FlexibleList } ?: return null
        if (Types.getRawType(type) != List::class.java) return null

        val elementType = Types.collectionElementType(type, List::class.java)
        val remainingAnnotations = annotations.filter { it !is FlexibleList }.toSet()
        @Suppress("UNCHECKED_CAST")
        val elementAdapter = moshi.adapter<Any>(elementType, remainingAnnotations) as JsonAdapter<Any>
        return FlexibleListAdapter(elementAdapter)
    }
}

private class FlexibleListAdapter<T>(
    private val elementAdapter: JsonAdapter<T>
) : JsonAdapter<List<T>>() {

    override fun fromJson(reader: JsonReader): List<T>? {
        return when (reader.peek()) {
            JsonReader.Token.NULL -> reader.nextNull()
            JsonReader.Token.BEGIN_ARRAY -> {
                val list = mutableListOf<T>()
                reader.beginArray()
                while (reader.hasNext()) {
                    elementAdapter.fromJson(reader)?.let { list.add(it) }
                }
                reader.endArray()
                list
            }
            JsonReader.Token.BEGIN_OBJECT -> {
                // PHP returns {"0": {...}, "1": {...}, "3": {...}} — sort by key and extract values
                val map = sortedMapOf<Int, T>()
                reader.beginObject()
                while (reader.hasNext()) {
                    val key = reader.nextName().toIntOrNull()
                    if (key == null) {
                        reader.skipValue()
                        continue
                    }
                    elementAdapter.fromJson(reader)?.let { map[key] = it }
                }
                reader.endObject()
                map.values.toList()
            }
            else -> null
        }
    }

    override fun toJson(writer: JsonWriter, value: List<T>?) {
        if (value == null) {
            writer.nullValue()
            return
        }
        writer.beginArray()
        for (item in value) elementAdapter.toJson(writer, item)
        writer.endArray()
    }
}
