import { AppDataSource } from "../config/data-source.js";
import { HistorialRastreo } from "../entities/HistorialRastreo.js";

export class HistorialRastreoRepository {
    private repository = AppDataSource.getRepository(HistorialRastreo);

    async create(historialData: Partial<HistorialRastreo>): Promise<HistorialRastreo> {
        const historial = this.repository.create(historialData);
        return await this.repository.save(historial);
    }
}

export const historialRastreoRepository = new HistorialRastreoRepository();
