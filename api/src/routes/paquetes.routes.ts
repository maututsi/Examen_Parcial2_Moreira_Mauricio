import { Router } from "express";
import { getPaqueteById, getPaquetes } from "../controllers/paquetes.controller.js";

const router = Router();

router.get("/", getPaquetes);
router.get("/:id", getPaqueteById);

export default router;
