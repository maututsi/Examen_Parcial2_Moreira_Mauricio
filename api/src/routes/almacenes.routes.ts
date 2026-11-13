import { Router } from "express";
import { addPaqueteToAlmacen } from "../controllers/almacenes.controller.js";

const router = Router();

router.post("/:id/paquetes", addPaqueteToAlmacen);

export default router;
