import { AppDataSource } from "../config/data-source.js";
import { Paquete } from "../entities/Paquete.js";

export class PaqueteRepository {
    private repository = AppDataSource.getRepository(Paquete);

    async findAll(): Promise<Paquete[]> {
        return await this.repository.find({
            relations: { envio: true, almacen: true },
            order: { id: "ASC" }
        });
    }

    async findById(id: number): Promise<Paquete | null> {
        return await this.repository.findOne({
            where: { id: id },
            relations: { envio: true, almacen: true }
        });
    }

    async create(paqueteData: Partial<Paquete>): Promise<Paquete> {
        const paquete = this.repository.create(paqueteData);
        return await this.repository.save(paquete);
    }
}

export const paqueteRepository = new PaqueteRepository();
