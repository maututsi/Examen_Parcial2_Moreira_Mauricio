import { Router } from "express";
import { getDireccionById, getDirecciones } from "../controllers/direcciones.controller.js";

const router = Router();

router.get("/", getDirecciones);
router.get("/:id", getDireccionById);

export default router;
