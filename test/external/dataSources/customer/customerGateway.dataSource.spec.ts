import { ApiGatewayCustomerDataSource } from 'src/external/dataSources/customer/apiGatewayCustomer.dataSource';
import { CustomerDataSourceDTO } from 'src/common/dataSource/DTOs/customerDataSource.dto';
import { CustomerGatewayDataSource } from 'src/external/dataSources/customer/CustomerGatewayDataSource';

// Mock fetch globally
global.fetch = jest.fn();

describe('CustomerGatewayDataSource', () => {
  let customerGatewayDataSource: CustomerGatewayDataSource;

  const mockCustomer: CustomerDataSourceDTO = {
    id: '123',
    cpf: '12345678901',
    name: 'John Doe',
    email: 'john@example.com',
    createdAt: '2023-01-01T00:00:00Z',
    updatedAt: '2023-01-01T00:00:00Z',
  };

  beforeEach(() => {
    customerGatewayDataSource = new ApiGatewayCustomerDataSource();

    // Set environment variables
    process.env.CUSTOMERS_GATEWAY_URL = 'https://api.gateway.com/v1';
    process.env.AUTHORIZER_KEY = 'test-auth-key';

    // Reset fetch mock
    (fetch as jest.Mock).mockReset();
  });

  afterEach(() => {
    delete process.env.CUSTOMERS_GATEWAY_URL;
    delete process.env.AUTHORIZER_KEY;
  });

  describe('findCustomerByCpf', () => {
    describe('when gateway returns customer successfully', () => {
      it('should return customer data', async () => {
        (fetch as jest.Mock).mockResolvedValue({
          ok: true,
          status: 200,
          json: () => Promise.resolve(mockCustomer),
        });

        const result =
          await customerGatewayDataSource.findCustomerByCpf('12345678901');

        expect(result).toEqual(mockCustomer);
        expect(fetch).toHaveBeenCalledWith(
          'https://api.gateway.com/v1/customers?cpf=12345678901',
          {
            method: 'GET',
            headers: {
              'Content-Type': 'application/json',
              authorizer: 'test-auth-key',
            },
          },
        );
      });
    });

    describe('when customer is not found', () => {
      it('should return null for 404 status', async () => {
        (fetch as jest.Mock).mockResolvedValue({
          ok: false,
          status: 404,
          statusText: 'Not Found',
        });

        const result =
          await customerGatewayDataSource.findCustomerByCpf('12345678901');

        expect(result).toBeNull();
      });
    });

    describe('when gateway returns error', () => {
      it('should return null and log error for server errors', async () => {
        const consoleErrorSpy = jest
          .spyOn(console, 'error')
          .mockImplementation();

        (fetch as jest.Mock).mockResolvedValue({
          ok: false,
          status: 500,
          statusText: 'Internal Server Error',
        });

        const result =
          await customerGatewayDataSource.findCustomerByCpf('12345678901');

        expect(result).toBeNull();
        expect(consoleErrorSpy).toHaveBeenCalledWith(
          'Error fetching customer from gateway:',
          expect.any(Error),
        );

        consoleErrorSpy.mockRestore();
      });

      it('should return null and log error when fetch fails', async () => {
        const consoleErrorSpy = jest
          .spyOn(console, 'error')
          .mockImplementation();

        (fetch as jest.Mock).mockRejectedValue(new Error('Network error'));

        const result =
          await customerGatewayDataSource.findCustomerByCpf('12345678901');

        expect(result).toBeNull();
        expect(consoleErrorSpy).toHaveBeenCalledWith(
          'Error fetching customer from gateway:',
          expect.any(Error),
        );

        consoleErrorSpy.mockRestore();
      });
    });

    describe('when environment variables are missing', () => {
      it('should return null when CUSTOMERS_GATEWAY_URL is missing', async () => {
        delete process.env.CUSTOMERS_GATEWAY_URL;
        const consoleErrorSpy = jest
          .spyOn(console, 'error')
          .mockImplementation();

        const result =
          await customerGatewayDataSource.findCustomerByCpf('12345678901');

        expect(result).toBeNull();
        expect(consoleErrorSpy).toHaveBeenCalledWith(
          'Error fetching customer from gateway:',
          expect.any(Error),
        );

        consoleErrorSpy.mockRestore();
      });

      it('should return null when AUTHORIZER_KEY is missing', async () => {
        delete process.env.AUTHORIZER_KEY;
        const consoleErrorSpy = jest
          .spyOn(console, 'error')
          .mockImplementation();

        const result =
          await customerGatewayDataSource.findCustomerByCpf('12345678901');

        expect(result).toBeNull();
        expect(consoleErrorSpy).toHaveBeenCalledWith(
          'Error fetching customer from gateway:',
          expect.any(Error),
        );

        consoleErrorSpy.mockRestore();
      });
    });

    describe('when response data is invalid', () => {
      it('should return null for invalid response structure', async () => {
        (fetch as jest.Mock).mockResolvedValue({
          ok: true,
          status: 200,
          json: () => Promise.resolve({ invalid: 'data' }),
        });

        const result =
          await customerGatewayDataSource.findCustomerByCpf('12345678901');

        expect(result).toBeNull();
      });

      it('should return null for null response', async () => {
        (fetch as jest.Mock).mockResolvedValue({
          ok: true,
          status: 200,
          json: () => Promise.resolve(null),
        });

        const result =
          await customerGatewayDataSource.findCustomerByCpf('12345678901');

        expect(result).toBeNull();
      });
    });
  });
});
