import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import '../../pos/data/models/cart_item_model.dart';
import '../../../core/utils/currency_formatter.dart';

class PrinterService {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  Future<List<BluetoothDevice>> getDevices() async {
    return await bluetooth.getBondedDevices();
  }

  Future<void> connect(BluetoothDevice device) async {
    bool? isConnected = await bluetooth.isConnected;
    if (isConnected == false) {
      await bluetooth.connect(device);
    }
  }

  Future<void> printReceipt({
    required List<CartItem> items, 
    required double total, 
    required double paymentAmount, 
    required double change
  }) async {
    bool? isConnected = await bluetooth.isConnected;
    
    if (isConnected == true) {
      bluetooth.printNewLine();
      
      bluetooth.printCustom("SMART KASIR POS", 2, 1); 
      bluetooth.printCustom("Jl. Jendral Sudirman No.123", 1, 1);
      bluetooth.printCustom("--------------------------------", 1, 1);
      
      for (var item in items) {
        String itemName = item.product.name;
        String qty = '${item.quantity}x';
        String price = formatRupiah(item.subtotal);
        
        bluetooth.printLeftRight(itemName, "$qty  $price", 1);
      }
      
      bluetooth.printCustom("--------------------------------", 1, 1);
      
      bluetooth.printLeftRight("TOTAL", formatRupiah(total), 1, format: "%s %s\n");
      bluetooth.printLeftRight("TUNAI", formatRupiah(paymentAmount), 1);
      bluetooth.printLeftRight("KEMBALIAN", formatRupiah(change), 1);
      
      bluetooth.printNewLine();
      bluetooth.printCustom("Terima Kasih Atas Kunjungan Anda", 1, 1);
      bluetooth.printNewLine();
      bluetooth.printNewLine();
      
      bluetooth.paperCut(); 
    } else {
      throw Exception('Printer tidak terhubung');
    }
  }
}
