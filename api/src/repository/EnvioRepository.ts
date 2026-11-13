import { AppDataSource } from "../config/data-source.js";
import { Envio, StatusEnvio } from "../entities/Envio.js";
import { Paquete } from "../entities/Paquete.js";

export class EnvioRepository {
    private repository = AppDataSource.getRepository(Envio);

    async findById(id: number): Promise<Envio | null> {
        return await this.repository.findOne({
            where: { id: id },
            relations: { remitente: true, destinatario: true, paquetes: true, historial: true }
        });
    }

    async findActivos(): Promise<Envio[]> {
        return await this.repository
            .createQueryBuilder("envio")
            .leftJoinAndSelect("envio.remitente", "remitente")
            .leftJoinAndSelect("envio.destinatario", "destinatario")
            .leftJoinAndSelect("envio.paquetes", "paquete")
            .where("envio.statusGlobal IN (:...estados)", {
                estados: [StatusEnvio.REGISTRADO, StatusEnvio.EN_TRANSITO]
            })
            .orderBy("envio.fecha", "DESC")
            .getMany();
    }

    async findByClienteId(idCliente: number): Promise<Envio[]> {
        return await this.repository
            .createQueryBuilder("envio")
            .leftJoinAndSelect("envio.remitente", "remitente")
            .leftJoinAndSelect("envio.destinatario", "destinatario")
            .leftJoinAndSelect("envio.paquetes", "paquete")
            .where("envio.idRemitente = :idCliente OR envio.idDestinatario = :idCliente", { idCliente })
            .orderBy("envio.fecha", "DESC")
            .getMany();
    }

    async createWithPaquetes(envioData: Partial<Envio>, paquetesData: Partial<Paquete>[]): Promise<Envio> {
        return await this.repository.manager.transaction(async (manager) => {
            const envio = await manager.save(manager.create(Envio, envioData));
            const paquetes = paquetesData.map((p) => manager.create(Paquete, { ...p, idEnvio: envio.id }));
            await manager.save(paquetes);
            return envio;
        });
    }

    async updateCosto(id: number, costoTotal: string): Promise<Envio | null> {
        await this.repository.update(id, { costoTotal });
        return await this.findById(id);
    }
}

export const envioRepository = new EnvioRepository();
