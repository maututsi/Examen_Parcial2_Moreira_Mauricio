import { AppDataSource } from "../config/data-source.js";
import { Cliente } from "../entities/Cliente.js";

export class ClienteRepository {
    private repository = AppDataSource.getRepository(Cliente);

    async findById(id: number): Promise<Cliente | null> {
        return await this.repository.findOne({
            where: { id: id },
            relations: { direccion: true }
        });
    }
}

export const clienteRepository = new ClienteRepository();
