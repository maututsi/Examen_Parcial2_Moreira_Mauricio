import type { Request, Response } from "express";
import { paqueteRepository } from "../repository/PaqueteRepository.js";

export const getPaquetes = async (req: Request, res: Response) => {
    try {
        const paquetes = await paqueteRepository.findAll();
        return res.status(200).json({ paquetes });
    } catch (e) {
        return res.status(500).json({ message: "No se pudieron recuperar los paquetes", status: 500 });
    }
}

export const getPaqueteById = async (req: Request, res: Response) => {
    try {
        const id = Number(req.params.id);
        if (!Number.isInteger(id)) {
            return res.status(400).json({ message: "Id de paquete inválido", status: 400 });
        }
        const paquete = await paqueteRepository.findById(id);
        if (!paquete) {
            return res.status(404).json({ message: "Paquete no encontrado", status: 404 });
        }
        return res.status(200).json({ paquete });
    } catch (e) {
        return res.status(500).json({ message: "No se pudo recuperar el paquete", status: 500 });
    }
}
