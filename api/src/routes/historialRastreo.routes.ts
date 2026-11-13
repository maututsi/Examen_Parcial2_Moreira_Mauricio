import { Router } from "express";
import { getHistorialRastreo, getHistorialRastreoById } from "../controllers/historialRastreo.controller.js";

const router = Router();

router.get("/", getHistorialRastreo);
router.get("/:id", getHistorialRastreoById);

export default router;
