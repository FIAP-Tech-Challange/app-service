import { Module, Global } from '@nestjs/common';
import { ApiGatewayCustomerDataSource } from 'src/external/dataSources/customer/apiGatewayCustomer.dataSource';
import { DataSourceProxy } from 'src/external/dataSources/dataSource.proxy';
import { createPostgresGeneralDataSource } from 'src/external/dataSources/general/postgres/createPostgresDataSource';
import { FakeEmailDataSource } from 'src/external/dataSources/notification/email/fakeEmailDataSource';
import { FakeMonitorDataSource } from 'src/external/dataSources/notification/monitor/fakeMonitorDataSource';
import { NotificationDataSourceProxy } from 'src/external/dataSources/notification/notificationDataSourceProxy';
import { FakeSmsDataSource } from 'src/external/dataSources/notification/sms/fakeSmsDataSource';
import { FakeWhatsAppDataSource } from 'src/external/dataSources/notification/whatsapp/fakeWhatsappDataSource';
import { FakePaymentDataSource } from 'src/external/dataSources/payment/fake/fakePaymentDataSource';

@Global()
@Module({
  providers: [
    {
      provide: DataSourceProxy,
      useFactory: async () => {
        const generalDataSource = await createPostgresGeneralDataSource();
        const paymentDataSource = new FakePaymentDataSource();
        const notificationDataSource = new NotificationDataSourceProxy(
          new FakeSmsDataSource(),
          new FakeWhatsAppDataSource(),
          new FakeEmailDataSource(),
          new FakeMonitorDataSource(),
        );
        const customerGatewayDataSource = new ApiGatewayCustomerDataSource();

        return new DataSourceProxy(
          generalDataSource,
          paymentDataSource,
          notificationDataSource,
          customerGatewayDataSource,
        );
      },
    },
  ],
  exports: [DataSourceProxy],
})
export class DataSourceModule {}
