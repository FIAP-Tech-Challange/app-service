import { ApiGatewayCustomerDataSource } from 'src/external/dataSources/customer/apiGatewayCustomer.dataSource';

export const createMockCustomerGatewayDataSource = () =>
  ({
    findCustomerByCpf: jest.fn(),
  }) as unknown as ApiGatewayCustomerDataSource;
