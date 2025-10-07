/* eslint-disable @typescript-eslint/unbound-method */
import { DataSourceProxy } from 'src/external/dataSources/dataSource.proxy';
import { GeneralDataSource } from 'src/external/dataSources/general/general.dataSource';
import { PaymentDataSource } from 'src/external/dataSources/payment/payment.dataSource';
import { NotificationDataSource } from 'src/external/dataSources/notification/notification.dataSource';
import { CustomerDataSourceDTO } from 'src/common/dataSource/DTOs/customerDataSource.dto';
import { CustomerGatewayDataSource } from 'src/external/dataSources/customer/CustomerGatewayDataSource';

describe('DataSourceProxy - findCustomerByCpf', () => {
  let dataSourceProxy: DataSourceProxy;
  let mockGeneralDataSource: Partial<GeneralDataSource>;
  let mockPaymentDataSource: Partial<PaymentDataSource>;
  let mockNotificationDataSource: Partial<NotificationDataSource>;
  let mockCustomerGatewayDataSource: jest.Mocked<CustomerGatewayDataSource>;

  const mockCustomer: CustomerDataSourceDTO = {
    id: '123',
    cpf: '12345678901',
    name: 'John Doe',
    email: 'john@example.com',
    createdAt: '2023-01-01T00:00:00Z',
    updatedAt: '2023-01-01T00:00:00Z',
  };

  beforeEach(() => {
    mockGeneralDataSource = {};
    mockPaymentDataSource = {};
    mockNotificationDataSource = {};

    // Mock CustomerGatewayDataSource
    mockCustomerGatewayDataSource = {
      findCustomerByCpf: jest.fn(),
    } as unknown as jest.Mocked<CustomerGatewayDataSource>;

    dataSourceProxy = new DataSourceProxy(
      mockGeneralDataSource as GeneralDataSource,
      mockPaymentDataSource as PaymentDataSource,
      mockNotificationDataSource as NotificationDataSource,
      mockCustomerGatewayDataSource,
    );
  });

  describe('findCustomerByCpf', () => {
    it('should delegate to CustomerGatewayDataSource and return customer data', async () => {
      mockCustomerGatewayDataSource.findCustomerByCpf.mockResolvedValue(
        mockCustomer,
      );

      const result = await dataSourceProxy.findCustomerByCpf('12345678901');

      expect(result).toEqual(mockCustomer);
      expect(
        mockCustomerGatewayDataSource.findCustomerByCpf,
      ).toHaveBeenCalledWith('12345678901');
      expect(
        mockCustomerGatewayDataSource.findCustomerByCpf,
      ).toHaveBeenCalledTimes(1);
    });

    it('should delegate to CustomerGatewayDataSource and return null when customer not found', async () => {
      mockCustomerGatewayDataSource.findCustomerByCpf.mockResolvedValue(null);

      const result = await dataSourceProxy.findCustomerByCpf('12345678901');

      expect(result).toBeNull();
      expect(
        mockCustomerGatewayDataSource.findCustomerByCpf,
      ).toHaveBeenCalledWith('12345678901');
      expect(
        mockCustomerGatewayDataSource.findCustomerByCpf,
      ).toHaveBeenCalledTimes(1);
    });

    it('should delegate to CustomerGatewayDataSource with correct CPF parameter', async () => {
      const testCpf = '98765432100';
      mockCustomerGatewayDataSource.findCustomerByCpf.mockResolvedValue(null);

      await dataSourceProxy.findCustomerByCpf(testCpf);

      expect(
        mockCustomerGatewayDataSource.findCustomerByCpf,
      ).toHaveBeenCalledWith(testCpf);
    });
  });
});
