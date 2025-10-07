import { CustomerDataSourceDTO } from 'src/common/dataSource/DTOs/customerDataSource.dto';
import { CustomerGatewayDataSource } from './CustomerGatewayDataSource';
import 'dotenv/config';

export class ApiGatewayCustomerDataSource implements CustomerGatewayDataSource {
  async findCustomerByCpf(cpf: string): Promise<CustomerDataSourceDTO | null> {
    try {
      return await this.fetchCustomerFromGateway(cpf);
    } catch (error) {
      console.error('Error fetching customer from gateway:', error);
      return null;
    }
  }

  private async fetchCustomerFromGateway(
    cpf: string,
  ): Promise<CustomerDataSourceDTO | null> {
    const gatewayUrl = process.env.CUSTOMERS_GATEWAY_URL;
    const authorizerKey = process.env.AUTHORIZER_KEY;

    if (!gatewayUrl || !authorizerKey) {
      throw new Error(
        'Missing gateway configuration: CUSTOMERS_GATEWAY_URL or AUTHORIZER_KEY',
      );
    }

    const response = await fetch(`${gatewayUrl}/customers/verify?cpf=${cpf}`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        Authorization: authorizerKey,
      },
    });

    const data = await response.json();

    if (!data.success) {
      if (response.status === 404) {
        return null;
      }
      throw new Error(
        `Gateway request failed: ${response.status} ${response.statusText}`,
      );
    }

    return this.validateCustomerResponse(data.data);
  }

  private validateCustomerResponse(
    data: unknown,
  ): CustomerDataSourceDTO | null {
    if (!data || typeof data !== 'object') {
      return null;
    }

    const customer = data as Record<string, unknown>;

    if (
      typeof customer.id === 'string' &&
      typeof customer.cpf === 'string' &&
      typeof customer.name === 'string' &&
      typeof customer.email === 'string' &&
      typeof customer.createdAt === 'string' &&
      typeof customer.updatedAt === 'string'
    ) {
      return {
        id: customer.id,
        cpf: customer.cpf,
        name: customer.name,
        email: customer.email,
        createdAt: customer.createdAt,
        updatedAt: customer.updatedAt,
      };
    }

    return null;
  }
}
