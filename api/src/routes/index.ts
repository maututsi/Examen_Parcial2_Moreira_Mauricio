import { Router } from "express";
import enviosRoutes from "./envios.routes.js";
import almacenesRoutes from "./almacenes.routes.js";
import clientesRoutes from "./clientes.routes.js";
import direccionesRoutes from "./direcciones.routes.js";
import paquetesRoutes from "./paquetes.routes.js";
import historialRastreoRoutes from "./historialRastreo.routes.js";
import auditoriaEnviosRoutes from "./auditoriaEnvios.routes.js";

const router = Router();

router.use("/envios", enviosRoutes);
router.use("/almacenes", almacenesRoutes);
router.use("/clientes", clientesRoutes);
router.use("/direcciones", direccionesRoutes);
router.use("/paquetes", paquetesRoutes);
router.use("/historial-rastreo", historialRastreoRoutes);
router.use("/auditoria-envios", auditoriaEnviosRoutes);

export default router;
