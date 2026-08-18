package kotlinx.serialization.json
open class Json {
    var ignoreUnknownKeys: Boolean = false
    var encodeDefaults: Boolean = false
    inline fun <reified T> encodeToString(value: T): String = ""
    companion object : Json()
}
fun Json(from: Json = Json, builder: Json.() -> Unit): Json = Json().apply(builder)
