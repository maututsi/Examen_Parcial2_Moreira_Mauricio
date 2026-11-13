import { AppDataSource } from "../config/data-source.js";
import { HistorialRastreo } from "../entities/HistorialRastreo.js";

export class HistorialRastreoRepository {
    private repository = AppDataSource.getRepository(HistorialRastreo);

    async findAll(): Promise<HistorialRastreo[]> {
        return await this.repository.find({
            order: { fecha: "ASC", id: "ASC" }
        });
    }

    async findById(id: number): Promise<HistorialRastreo | null> {
        return await this.repository.findOne({
            where: { id: id },
            relations: { envio: true }
        });
    }

    async create(historialData: Partial<HistorialRastreo>): Promise<HistorialRastreo> {
        const historial = this.repository.create(historialData);
        return await this.repository.save(historial);
    }
}

export const historialRastreoRepository = new HistorialRastreoRepository();
