import type { Request, Response } from "express";
import { direccionRepository } from "../repository/DireccionRepository.js";

export const getDirecciones = async (req: Request, res: Response) => {
    try {
        const direcciones = await direccionRepository.findAll();
        return res.status(200).json({ direcciones });
    } catch (e) {
        return res.status(500).json({ message: "No se pudieron recuperar las direcciones", status: 500 });
    }
}

export const getDireccionById = async (req: Request, res: Response) => {
    try {
        const id = Number(req.params.id);
        if (!Number.isInteger(id)) {
            return res.status(400).json({ message: "Id de dirección inválido", status: 400 });
        }
        const direccion = await direccionRepository.findById(id);
        if (!direccion) {
            return res.status(404).json({ message: "Dirección no encontrada", status: 404 });
        }
        return res.status(200).json({ direccion });
    } catch (e) {
        return res.status(500).json({ message: "No se pudo recuperar la dirección", status: 500 });
    }
}
