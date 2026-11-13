import type { Request, Response } from "express";
import { almacenRepository } from "../repository/AlmacenRepository.js";
import { envioRepository } from "../repository/EnvioRepository.js";
import { paqueteRepository } from "../repository/PaqueteRepository.js";
import { getTriggerError } from "../dbErrors.js";

export const addPaqueteToAlmacen = async (req: Request, res: Response) => {
    try {
        const idAlmacen = Number(req.params.id);
        const { idEnvio, peso, alto, largo, ancho, contenido } = req.body ?? {};

        if (!Number.isInteger(idAlmacen) || !Number.isInteger(idEnvio)
            || typeof peso !== "number" || typeof alto !== "number"
            || typeof largo !== "number" || typeof ancho !== "number"
            || typeof contenido !== "string" || contenido.length === 0) {
            return res.status(400).json({
                message: "Se requiere un id de almacén válido, idEnvio, peso, alto, largo, ancho (numéricos) y contenido",
                status: 400
            });
        }

        const almacen = await almacenRepository.findById(idAlmacen);
        if (!almacen) return res.status(404).json({ message: "Almacén no encontrado", status: 404 });
        

        const envio = await envioRepository.findById(idEnvio);
        if (!envio) return res.status(404).json({ message: "Envío no encontrado", status: 404 });
        

        const paquete = await paqueteRepository.create({
            peso,
            alto,
            largo,
            ancho,
            contenido,
            idEnvio,
            idAlmacen
        });
        return res.status(201).json({ paquete });
    } catch (e) {
        const triggerMessage = getTriggerError(e);
        if (triggerMessage) {
            return res.status(400).json({ message: triggerMessage, status: 400 });
        }
        return res.status(500).json({
            message: "No se pudo registrar el paquete en el almacén",
            status: 500
        });
    }
}
