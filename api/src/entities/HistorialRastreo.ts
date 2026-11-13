import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn, type Relation } from "typeorm";
import { Envio } from "./Envio.js";
import { StatusEnvio } from "./StatusEnvio.js";

@Entity({ name: "historial_rastreo" })
export class HistorialRastreo {
    @PrimaryGeneratedColumn()
    id!: number;

    @Column({ type: "datetime" })
    fecha!: Date;

    @Column({ name: "ubicacion_actual", type: "varchar", length: 150 })
    ubicacionActual!: string;

    @Column({ name: "status_evento", type: "enum", enum: StatusEnvio })
    statusEvento!: StatusEnvio;

    @Column({ type: "varchar", length: 200, nullable: true })
    observaciones!: string | null;

    @Column({ name: "id_envio", type: "int" })
    idEnvio!: number;

    @ManyToOne(() => Envio, (envio) => envio.historial)
    @JoinColumn({ name: "id_envio", foreignKeyConstraintName: "fk_historial_envios" })
    envio?: Relation<Envio>;
}
