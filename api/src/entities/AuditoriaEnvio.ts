import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn, type Relation } from "typeorm";
import { Envio } from "./Envio.js";

@Entity({ name: "auditoria_envios" })
export class AuditoriaEnvio {
    @PrimaryGeneratedColumn()
    id!: number;

    @Column({ name: "id_envio", type: "int" })
    idEnvio!: number;

    @Column({ name: "costo_anterior", type: "decimal", precision: 15, scale: 2 })
    costoAnterior!: string;

    @Column({ name: "costo_nuevo", type: "decimal", precision: 15, scale: 2 })
    costoNuevo!: string;

    @Column({ type: "varchar", length: 100 })
    usuario!: string;

    @Column({ name: "fecha_modificacion", type: "datetime" })
    fechaModificacion!: Date;

    @ManyToOne(() => Envio, (envio) => envio.auditorias)
    @JoinColumn({ name: "id_envio", foreignKeyConstraintName: "fk_auditoria_envios" })
    envio?: Relation<Envio>;
}
