import { AppDataSource } from "../config/data-source.js";
import { Almacen } from "../entities/Almacen.js";
import { Paquete } from "../entities/Paquete.js";

export class AlmacenRepository {
    private repository = AppDataSource.getRepository(Almacen);

    // Almacenes con su ocupación actual (número de paquetes dentro), sin cargar los paquetes
    async findAll(): Promise<Almacen[]> {
        const { entities, raw } = await this.repository
            .createQueryBuilder("almacen")
            .addSelect((sub) => sub
                .select("COUNT(*)")
                .from(Paquete, "p")
                .where("p.id_almacen = almacen.id"), "ocupacion")
            .orderBy("almacen.id", "ASC")
            .getRawAndEntities();

        // Sin joins, raw y entities vienen en el mismo orden (una fila por almacén)
        entities.forEach((almacen, i) => {
            almacen.ocupacion = Number(raw[i]?.ocupacion ?? 0);
        });
        return entities;
    }

    // Almacén con los paquetes que tiene dentro
    async findByIdConPaquetes(id: number): Promise<Almacen | null> {
        const almacen = await this.repository.findOne({
            where: { id: id },
            relations: { paquetes: true }
        });
        if (almacen) {
            almacen.ocupacion = almacen.paquetes?.length ?? 0;
        }
        return almacen;
    }

    async findById(id: number): Promise<Almacen | null> {
        return await this.repository.findOneBy({ id: id });
    }
}

export const almacenRepository = new AlmacenRepository();
