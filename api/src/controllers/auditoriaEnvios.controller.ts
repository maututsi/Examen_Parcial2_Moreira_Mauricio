import type { Request, Response } from "express";
import { auditoriaEnvioRepository } from "../repository/AuditoriaEnvioRepository.js";

export const getAuditoriasEnvio = async (req: Request, res: Response) => {
    try {
        const auditorias = await auditoriaEnvioRepository.findAll();
        return res.status(200).json({ auditorias });
    } catch (e) {
        return res.status(500).json({ message: "No se pudo recuperar la auditoría de envíos", status: 500 });
    }
}

export const getAuditoriaEnvioById = async (req: Request, res: Response) => {
    try {
        const id = Number(req.params.id);
        if (!Number.isInteger(id)) {
            return res.status(400).json({ message: "Id de auditoría inválido", status: 400 });
        }
        const auditoria = await auditoriaEnvioRepository.findById(id);
        if (!auditoria) {
            return res.status(404).json({ message: "Registro de auditoría no encontrado", status: 404 });
        }
        return res.status(200).json({ auditoria });
    } catch (e) {
        return res.status(500).json({ message: "No se pudo recuperar el registro de auditoría", status: 500 });
    }
}
