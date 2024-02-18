import 'package:flutter/material.dart';
import 'provider/company.dart';

class Ledger extends StatefulWidget {
  const Ledger({super.key});

  @override
  State createState() => _LedgerState();
}

List<Map> company = [
  {'name': JRM().name, 'value': JRM().value},
  {'name': AYI().name, 'value': AYI().value}
];

partyContainer() {
  return Container(
    width: double.infinity,
    child: Card(
      color: Colors.white10,
      shadowColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: const Row(
          children: [
            Flexible(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pary Name',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text('Last Sale Details',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                          flex: 1,
                          child: Text(
                            'Date\n12/3/2022',
                            style: TextStyle(fontSize: 12),
                          )),
                      Flexible(
                          flex: 1,
                          child: Text('Invoice No.',
                              style: TextStyle(fontSize: 12))),
                      Flexible(
                          flex: 1,
                          child: Text(
                            'Value\n10,10,110.10',
                            style: TextStyle(fontSize: 12),
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ))
                    ],
                  ),
                ],
              ),
            ),
            VerticalDivider(
              width: 8,
              thickness: 1,
              color: Colors.black,
              indent: 5,
              endIndent: 5,
            ),
            Flexible(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  Text(
                    'Last Payment Details',
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text('Value', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LedgerState extends State<Ledger> {
  Map? selectedCompany = company.first;
  bool filterApplied = false;
  DateTime? startDate;
  DateTime? endDate;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger'),
        backgroundColor: Colors.amber,
        elevation: 1,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10, top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(10)),
                      width: 20,
                      child: DropdownButton<Map>(
                          alignment: Alignment.center,
                          isExpanded: true,
                          dropdownColor: Colors.grey,
                          value: selectedCompany,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.white),
                          style:
                              const TextStyle(color: Colors.white, fontSize: 16),
                          items: company.map<DropdownMenuItem<Map>>((curr) {
                            return DropdownMenuItem<Map>(
                                value: curr, child: Text(curr['name']));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCompany = value;
                            });
                          })),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(10)),
                  child: TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15))),
                          context: context,
                          builder: (context) {
                            return Container(
                              height: MediaQuery.of(context).size.height / 2,
                              child: Column(children: [
                                TextButton.icon(
                                  onPressed: () async {
                                    final range = await showDateRangePicker(
                                        context: context,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now());
                                    setState(() {
                                      startDate = range!.start;
                                      endDate = range.end;
                                    });
                                  },
                                  icon: const Icon(Icons.calendar_month),
                                  label: const Text('Date Range'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    setState(() {
                                      filterApplied = true;
                                    });
                                  },
                                  child: const Text('Apply'),
                                )
                              ]),
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.filter_alt,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Filter',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )),
                ),
              ],
            ),
          ),
          if (filterApplied)
            Container(
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    width: MediaQuery.of(context).size.width - 80,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('${startDate} to $endDate'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        filterApplied = false;
                      });
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text(''),
                  )
                ],
              ),
            ),
          Container(
            margin: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  partyContainer(),
                  partyContainer(),
                  partyContainer()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
