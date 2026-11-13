import { Router } from "express";
import { getAuditoriaEnvioById, getAuditoriasEnvio } from "../controllers/auditoriaEnvios.controller.js";

const router = Router();

router.get("/", getAuditoriasEnvio);
router.get("/:id", getAuditoriaEnvioById);

export default router;
