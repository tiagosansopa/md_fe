import 'package:flutter/material.dart';

class ProfileFormScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Nombre
            TextFormField(
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            SizedBox(height: 10),

            // Apellido
            TextFormField(
              decoration: InputDecoration(labelText: 'Apellido'),
            ),
            SizedBox(height: 10),

            // Apodo
            TextFormField(
              decoration: InputDecoration(labelText: 'Apodo'),
            ),
            SizedBox(height: 10),

            // Cumpleaños
            TextFormField(
              decoration: InputDecoration(labelText: 'Cumpleaños'),
              onTap: () {
                // Aquí puedes implementar un selector de fechas
              },
              readOnly: true,
            ),
            SizedBox(height: 10),

            // Género
            DropdownButtonFormField(
              decoration: InputDecoration(labelText: 'Género'),
              items: ['Masculino', 'Femenino', 'Otro']
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
              onChanged: (value) {
                // Maneja el cambio de género
              },
            ),
            SizedBox(height: 10),

            // Altura
            TextFormField(
              decoration: InputDecoration(labelText: 'Altura (cm)'),
              keyboardType: TextInputType.number,
            ),
            TextButton(
              onPressed: () {
                // Lógica para cambiar la dimensional (cm o pies/pulgadas)
              },
              child: Text('Cambiar unidad'),
            ),
            SizedBox(height: 10),

            // Peso
            TextFormField(
              decoration: InputDecoration(labelText: 'Peso (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextButton(
              onPressed: () {
                // Lógica para cambiar la dimensional (kg o libras)
              },
              child: Text('Cambiar unidad'),
            ),
            SizedBox(height: 10),

            // País
            TextFormField(
              decoration: InputDecoration(labelText: 'País'),
            ),
            SizedBox(height: 10),

            // Incapacidad
            DropdownButtonFormField(
              decoration: InputDecoration(labelText: 'Incapacidad'),
              items: ['Ninguna', 'Visual', 'Auditiva', 'Física']
                  .map((disability) => DropdownMenuItem(
                        value: disability,
                        child: Text(disability),
                      ))
                  .toList(),
              onChanged: (value) {
                // Maneja el cambio de incapacidad
              },
            ),
            SizedBox(height: 20),

            // Botón para guardar cambios
            ElevatedButton(
              onPressed: () {
                // Lógica para guardar cambios
              },
              child: Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
