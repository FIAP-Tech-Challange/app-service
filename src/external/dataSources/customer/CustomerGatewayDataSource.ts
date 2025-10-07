import { CustomerDataSourceDTO } from 'src/common/dataSource/DTOs/customerDataSource.dto';

export interface CustomerGatewayDataSource {
  findCustomerByCpf(cpf: string): Promise<CustomerDataSourceDTO | null>;
}
