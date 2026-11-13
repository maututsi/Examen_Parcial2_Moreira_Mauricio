import { AppDataSource } from "../config/data-source.js";
import { AuditoriaEnvio } from "../entities/AuditoriaEnvio.js";

export class AuditoriaEnvioRepository {
    private repository = AppDataSource.getRepository(AuditoriaEnvio);

    async findAll(): Promise<AuditoriaEnvio[]> {
        return await this.repository.find({
            order: { fechaModificacion: "DESC", id: "DESC" }
        });
    }

    async findById(id: number): Promise<AuditoriaEnvio | null> {
        return await this.repository.findOne({
            where: { id: id },
            relations: { envio: true }
        });
    }
}

export const auditoriaEnvioRepository = new AuditoriaEnvioRepository();
