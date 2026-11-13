import express from 'express';
import type { Request, Response } from 'express'
import routes from './routes/index.js';

const app = express();

app.use(express.json());

app.get('/api/status', (req: Request, res: Response) => {
  res.json({ status: 'OK', message: 'API funcionando correctamente' });
});

app.use('/api', routes);

export default app;