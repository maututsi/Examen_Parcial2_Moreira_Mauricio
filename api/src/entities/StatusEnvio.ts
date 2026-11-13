// En archivo propio (sin imports) para evitar la importación circular
// Envio <-> HistorialRastreo: así el enum ya existe cuando se evalúan los decoradores.
export enum StatusEnvio {
    REGISTRADO = "REGISTRADO",
    EN_TRANSITO = "EN_TRANSITO",
    ENTREGADO = "ENTREGADO",
    CANCELADO = "CANCELADO",
}
