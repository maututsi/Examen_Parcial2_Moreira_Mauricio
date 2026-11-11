import express from 'express';
import type { Request, Response } from 'express'
import userRoutes from './routes/user.routes.js'
import productRoutes from "./routes/product.routes.js"
import ventasRoutes from "./routes/ventas.routes.js"

const app = express();

// Middleware para parsear JSON
app.use(express.json());
app.use("/api/", userRoutes);
app.use("/api/", productRoutes);
app.use("/api/", ventasRoutes);

// Ruta de prueba/salud
app.get('/api/status', (req: Request, res: Response) => {
  res.json({ status: 'OK', message: 'API funcionando correctamente' });
});

export default app;