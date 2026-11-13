import type { Request, Response } from "express";
import { envioRepository } from "../repository/EnvioRepository.js";
import { clienteRepository } from "../repository/ClienteRepository.js";
import { almacenRepository } from "../repository/AlmacenRepository.js";
import { historialRastreoRepository } from "../repository/HistorialRastreoRepository.js";
import { StatusEnvio } from "../entities/StatusEnvio.js";
import { getTriggerError } from "../dbErrors.js";

export const getEnvios = async (req: Request, res: Response) => {
    try {
        const envios = await envioRepository.findActivos();
        return res.status(200).json({ envios });
    } catch (e) {
        return res.status(500).json({
            message: "No se han podido recuperar los envíos",
            status: 500
        });
    }
}

export const getEnvioById = async (req: Request, res: Response) => {
    try {
        const id = Number(req.params.id);
        const envio = await envioRepository.findById(id);
        if (!envio) {
            return res.status(404).json({ message: "Envío no encontrado", status: 404 });
        }
        return res.status(200).json({ envio });
    } catch (e) {
        return res.status(500).json({
            message: "No se pudo recuperar el envío",
            status: 500
        });
    }
}

// POST /api/envios -> alta de envío con sus paquetes iniciales (transacción)
export const createEnvio = async (req: Request, res: Response) => {
    try {
        const { idRemitente, idDestinatario, costoTotal, paquetes } = req.body ?? {};

        if (!Number.isInteger(idRemitente) || !Number.isInteger(idDestinatario)
            || typeof costoTotal !== "number" || costoTotal < 0
            || !Array.isArray(paquetes) || paquetes.length === 0) {
            return res.status(400).json({
                message: "Se requiere idRemitente, idDestinatario, costoTotal (>= 0) y al menos un paquete",
                status: 400
            });
        }

        const paquetesValidos = paquetes.every((p: any) =>
            typeof p?.peso === "number" && typeof p?.alto === "number"
            && typeof p?.largo === "number" && typeof p?.ancho === "number"
            && typeof p?.contenido === "string" && p.contenido.length > 0
            && (p.idAlmacen === undefined || p.idAlmacen === null || Number.isInteger(p.idAlmacen)));
        if (!paquetesValidos) {
            return res.status(400).json({
                message: "Cada paquete requiere peso, alto, largo, ancho (numéricos), contenido e idAlmacen opcional (entero)",
                status: 400
            });
        }

        const remitente = await clienteRepository.findById(idRemitente);
        const destinatario = await clienteRepository.findById(idDestinatario);

        if (!remitente || !destinatario) {
            return res.status(404).json({ message: "Remitente o destinatario no encontrado", status: 404 });
        }

        const envio = await envioRepository.createWithPaquetes(
            {
                idRemitente,
                idDestinatario,
                costoTotal: costoTotal.toFixed(2),
                fecha: new Date(),
                statusGlobal: StatusEnvio.REGISTRADO
            },
            paquetes.map((p: any) => ({
                peso: p.peso,
                alto: p.alto,
                largo: p.largo,
                ancho: p.ancho,
                contenido: p.contenido,
                idAlmacen: p.idAlmacen ?? null
            }))
        );

        const creado = await envioRepository.findById(envio.id);
        return res.status(201).json({ envio: creado });
    } catch (e) {
        const triggerMessage = getTriggerError(e);
        if (triggerMessage) {
            return res.status(400).json({ message: triggerMessage, status: 400 });
        }
        return res.status(500).json({
            message: "No se pudo registrar el envío",
            status: 500
        });
    }
}

// detona el trigger after_update_envio_costo
export const updateCostoEnvio = async (req: Request, res: Response) => {
    try {
        const id = Number(req.params.id);
        const { costoTotal } = req.body ?? {};

        if (typeof costoTotal !== "number" || costoTotal < 0) {
            return res.status(400).json({
                message: "costoTotal debe ser un número mayor o igual a 0",
                status: 400
            });
        }

        const existente = await envioRepository.findById(id);
        if (!existente) {
            return res.status(404).json({ message: "Envío no encontrado", status: 404 });
        }

        const envio = await envioRepository.updateCosto(id, costoTotal.toFixed(2));
        return res.status(200).json({ envio });
    } catch (e) {
        const triggerMessage = getTriggerError(e);
        if (triggerMessage) {
            return res.status(400).json({ message: triggerMessage, status: 400 });
        }
        return res.status(500).json({
            message: "No se pudo actualizar el costo del envío",
            status: 500
        });
    }
}

// detona el trigger after_insert_historial_rastreo
export const addRastreo = async (req: Request, res: Response) => {
    try {
        const idEnvio = Number(req.params.id);
        const { ubicacionActual, statusEvento, observaciones } = req.body ?? {};

        if (typeof ubicacionActual !== "string" || ubicacionActual.trim().length === 0
            || ubicacionActual.length > 150
            || !Object.values(StatusEnvio).includes(statusEvento)
            || (observaciones !== undefined && typeof observaciones !== "string")) {
            return res.status(400).json({
                message: `Se requiere ubicacionActual (máx. 150 caracteres) y statusEvento (${Object.values(StatusEnvio).join(", ")})`,
                status: 400
            });
        }

        const envio = await envioRepository.findById(idEnvio);
        if (!envio) {
            return res.status(404).json({ message: "Envío no encontrado", status: 404 });
        }

        const rastreo = await historialRastreoRepository.create({
            fecha: new Date(),
            ubicacionActual: ubicacionActual.trim(),
            statusEvento,
            observaciones: observaciones ?? null,
            idEnvio
        });

        const envioActualizado = await envioRepository.findById(idEnvio);
        return res.status(201).json({ rastreo, envio: envioActualizado });
    } catch (e) {
        const triggerMessage = getTriggerError(e);
        if (triggerMessage) {
            return res.status(400).json({ message: triggerMessage, status: 400 });
        }
        return res.status(500).json({
            message: "No se pudo registrar el rastreo",
            status: 500
        });
    }
}
