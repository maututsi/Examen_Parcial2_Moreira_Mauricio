import { Router } from "express";
import { addRastreo, createEnvio, getEnvioById, getEnvios, updateCostoEnvio } from "../controllers/envios.controller.js";

const router = Router();

router.get("/", getEnvios);
router.post("/", createEnvio);
router.get("/:id", getEnvioById);
router.put("/:id/costo", updateCostoEnvio);
router.post("/:id/rastreo", addRastreo);

export default router;
