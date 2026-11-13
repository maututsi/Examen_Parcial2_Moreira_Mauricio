import type { Request, Response } from "express";
import { historialRastreoRepository } from "../repository/HistorialRastreoRepository.js";

export const getHistorialRastreo = async (req: Request, res: Response) => {
    try {
        const historial = await historialRastreoRepository.findAll();
        return res.status(200).json({ historial });
    } catch (e) {
        return res.status(500).json({ message: "No se pudo recuperar el historial de rastreo", status: 500 });
    }
}

export const getHistorialRastreoById = async (req: Request, res: Response) => {
    try {
        const id = Number(req.params.id);
        if (!Number.isInteger(id)) {
            return res.status(400).json({ message: "Id de rastreo inválido", status: 400 });
        }
        const rastreo = await historialRastreoRepository.findById(id);
        if (!rastreo) {
            return res.status(404).json({ message: "Evento de rastreo no encontrado", status: 404 });
        }
        return res.status(200).json({ rastreo });
    } catch (e) {
        return res.status(500).json({ message: "No se pudo recuperar el evento de rastreo", status: 500 });
    }
}
