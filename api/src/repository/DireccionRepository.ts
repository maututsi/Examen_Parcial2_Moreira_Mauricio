import { AppDataSource } from "../config/data-source.js";
import { Direccion } from "../entities/Direccion.js";

export class DireccionRepository {
    private repository = AppDataSource.getRepository(Direccion);

    async findAll(): Promise<Direccion[]> {
        return await this.repository.find({
            relations: { cliente: true },
            order: { id: "ASC" }
        });
    }

    async findById(id: number): Promise<Direccion | null> {
        return await this.repository.findOne({
            where: { id: id },
            relations: { cliente: true }
        });
    }
}

export const direccionRepository = new DireccionRepository();
