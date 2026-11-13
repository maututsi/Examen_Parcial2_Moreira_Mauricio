import { Router } from "express";
import { addPaqueteToAlmacen, getAlmacenById, getAlmacenes } from "../controllers/almacenes.controller.js";

const router = Router();

router.get("/", getAlmacenes);
router.get("/:id", getAlmacenById);
router.post("/:id/paquetes", addPaqueteToAlmacen);

export default router;
