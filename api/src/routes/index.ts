import { Router } from "express";
import enviosRoutes from "./envios.routes.js";
import almacenesRoutes from "./almacenes.routes.js";
import clientesRoutes from "./clientes.routes.js";

const router = Router();

router.use("/envios", enviosRoutes);
router.use("/almacenes", almacenesRoutes);
router.use("/clientes", clientesRoutes);

export default router;
