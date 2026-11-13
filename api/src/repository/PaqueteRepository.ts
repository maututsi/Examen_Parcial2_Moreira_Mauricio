import { AppDataSource } from "../config/data-source.js";
import { Paquete } from "../entities/Paquete.js";

export class PaqueteRepository {
    private repository = AppDataSource.getRepository(Paquete);

    async create(paqueteData: Partial<Paquete>): Promise<Paquete> {
        const paquete = this.repository.create(paqueteData);
        return await this.repository.save(paquete);
    }
}

export const paqueteRepository = new PaqueteRepository();
