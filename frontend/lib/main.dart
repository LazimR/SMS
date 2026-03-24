import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:sms/position.dart';
import 'package:sms/send_message.dart' as tcp;
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static const Color batteryGreen = Color(0xFF22C55E); // >= 80%
  static const Color batteryYellow = Color(0xFFEAB308); // 50-79%
  static const Color batteryOrange = Color(0xFFF97316); // 20-49%
  static const Color batteryRed = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final TextEditingController ipController = TextEditingController();
    final TextEditingController portController = TextEditingController();
    Color batteryColor = batteryGreen;
    Position? position;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (dialogContext) {
          Future<void> handleEnviarDados() async {
            final host = ipController.text.trim();
            final port = int.tryParse(portController.text.trim());

            if (host.isEmpty || port == null) {
              if (!dialogContext.mounted) return;
              await showDialog<void>(
                context: dialogContext,
                builder: (ctx) => AlertDialog(
                  title: const Text('Atenção'),
                  content: const Text(
                    'Informe o IP e uma porta numérica válida.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
              return;
            }

            try {
              final batteryLevel = await Battery().batteryLevel;
              final pos = await userPosition();
              final ok = await tcp.sendData(
                host: host,
                port: port,
                level: batteryLevel,
                lat: pos.latitude.toString(),
                long: pos.longitude.toString(),
              );
              if (!dialogContext.mounted) return;
              await showDialog<void>(
                context: dialogContext,
                builder: (ctx) => AlertDialog(
                  title: Text(ok ? 'Sucesso' : 'Erro'),
                  content: Text(
                    ok
                        ? 'Os dados foram enviados ao servidor.'
                        : 'Não foi possível enviar. Verifique rede, IP e porta do servidor.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            } catch (e) {
              if (!dialogContext.mounted) return;
              await showDialog<void>(
                context: dialogContext,
                builder: (ctx) => AlertDialog(
                  title: const Text('Erro'),
                  content: Text(e.toString()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          }

          return Scaffold(
            backgroundColor: Colors.black,
            body: ListView(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Monitor de Sensor",
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          fontFamily: 'Geist',
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        "Coleta de bateria e GPS em tempo real",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: Color.fromARGB(173, 158, 158, 158),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 350,
                    height: 190,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Color(0xFF262626),
                      border: BoxBorder.all(color: Color(0xFF3F3F3F)),
                    ),
                    child: FutureBuilder<int>(
                      future: Battery().batteryLevel,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text('...'); // ainda carregando
                        }
                        final charge = snapshot.data!;

                        if (charge > 80) {
                          batteryColor = batteryGreen;
                        } else if (charge > 50) {
                          batteryColor = batteryYellow;
                        } else if (charge >= 20) {
                          batteryColor = batteryOrange;
                        } else {
                          batteryColor = batteryRed;
                        }
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bolt, color: batteryColor),
                                Text(
                                  "Bateria",
                                  style: TextStyle(
                                    color: batteryColor,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "Nível de carga do dispositivo",
                              style: TextStyle(
                                color: Color.fromARGB(173, 158, 158, 158),
                              ),
                            ),
                            Text(
                              '${snapshot.data}%',
                              style: TextStyle(
                                color: batteryColor,
                                fontSize: 60,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 350,
                    height: 200,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Color(0xFF262626),
                      border: BoxBorder.all(color: Color(0xFF3F3F3F)),
                    ),
                    child: Column(
                      spacing: 3,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.pin_drop_sharp, color: batteryColor),
                            const Text(
                              "Localização GPS",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "Coordenadas em tempo real",
                          style: TextStyle(
                            color: Color.fromARGB(173, 158, 158, 158),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FutureBuilder(
                          future: userPosition(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.green,
                                padding: EdgeInsets.all(10),
                              );
                            } else if (snapshot.hasError) {
                              return Text(
                                "Não foi possivel conseguir a localização",
                              );
                            } else {
                              position = snapshot.data;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 20,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "LONGITUDE",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                        ),
                                      ),
                                      Text(
                                        "${position?.longitude} ",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        "LATITUDE",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                        ),
                                      ),
                                      Text(
                                        "${position?.latitude} ",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 350,
                    height: 350,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Color(0xFF262626),
                      border: BoxBorder.all(color: Color(0xFF3F3F3F)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Configuração do Servidor",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "IP e porta do servidor TCP central",
                          style: TextStyle(
                            color: Color.fromARGB(173, 158, 158, 158),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "IP",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextField(
                          controller: ipController,
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Porta",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextField(
                          controller: portController,
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 25),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                            ),
                            onPressed: handleEnviarDados,
                            child: const Text("Enviar Dados"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
