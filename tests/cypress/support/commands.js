import 'cypress-file-upload';
import $ from 'jquery';
import _ from 'lodash';

Cypress.Commands.add('getDataFromDatatable', (datatable_testid) => {
  cy.get(`[data-testid="${datatable_testid}"]`).then(($datatable) => {
    const data = [];

    // Extract header data (excluding the first `th`)
    $datatable.find('thead tr:first-child').each((index, row) => {
      const rowData = [];
      $(row).find('th').each((index, cell) => {
        rowData.push($(cell).text());
      });
      data.push(rowData);
    });

    // Extract tbody data
    $datatable.find('tbody tr').each((index, row) => {
      const rowData = [];
      $(row).find('td').each((index, cell) => {
        rowData.push($(cell).text());
      });
      data.push(rowData);
    });

    return JSON.stringify(data);
  });
});

Cypress.Commands.add('importing_data_flow', () => {
  cy.get("#app-import_file-file").should('be.visible');
  cy.get('#app-import_file-upload_file')
      .should('not.be.visible')
      .selectFile('cypress/fixtures/csv_example.csv', {force: true});
  cy.get('#app-table_output-data_table').wait(5000);
  cy.get('#app-select_variables-sequence_variable').should('be.visible');
  cy.get('#app-select_variables-sequence_variable').click();
  cy.get('#app-select_variables-sequence_variable-list0').click();
  cy.get('#app-select_variables-forecast_variable').should('be.visible');
  cy.get('#app-select_variables-forecast_variable').click();
  cy.get('#app-select_variables-forecast_variable-list1').click();
});

Cypress.Commands.add('turn_panel', () => {
  cy.get('#app-page_buttons-nextbutton').should('be.visible');
  cy.get('#app-page_buttons-nextbutton').click();
});
