import { Router } from "express";
import { getClienteById, getClientes, getEnviosByCliente } from "../controllers/clientes.controller.js";

const router = Router();

router.get("/", getClientes);
router.get("/:id", getClienteById);
router.get("/:id/envios", getEnviosByCliente);

export default router;
