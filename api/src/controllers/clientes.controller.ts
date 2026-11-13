import type { Request, Response } from "express";
import { clienteRepository } from "../repository/ClienteRepository.js";
import { envioRepository } from "../repository/EnvioRepository.js";

// GET /api/clientes/:id/envios -> historial de envíos de un cliente
export const getEnviosByCliente = async (req: Request, res: Response) => {
    try {
        const id = Number(req.params.id);
        if (!Number.isInteger(id)) {
            return res.status(400).json({ message: "Id de cliente inválido", status: 400 });
        }

        const cliente = await clienteRepository.findById(id);
        if (!cliente) {
            return res.status(404).json({ message: "Cliente no encontrado", status: 404 });
        }

        const envios = await envioRepository.findByClienteId(id);
        return res.status(200).json({ cliente, envios });
    } catch (e) {
        return res.status(500).json({
            message: "No se pudo recuperar el historial de envíos del cliente",
            status: 500
        });
    }
}
