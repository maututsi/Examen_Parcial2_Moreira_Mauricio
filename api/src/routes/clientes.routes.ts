import { Router } from "express";
import { getEnviosByCliente } from "../controllers/clientes.controller.js";

const router = Router();

router.get("/:id/envios", getEnviosByCliente);

export default router;
