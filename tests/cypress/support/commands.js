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

Cypress.Commands.add('compare_table_fixture', (table, fixture) => {
  cy.fixture(fixture).then((expectedData) => {
    cy.getDataFromDatatable(table).then((currentData) => {
      expect(currentData).to.deep.equal(JSON.stringify(expectedData));
      if (currentData !== JSON.stringify(expectedData)) {
        cy.log('DataTable data does not match the expected data');
      } else {
        cy.log('DataTable data match the expected data');
      }
    });
  });
})

Cypress.Commands.add('importing_data_flow', (test_data) => {
  cy.get('[data-testid="file"]').should('be.visible');
  cy.get('[data-testid="upload_file"] [type="file"]')
      .should('not.be.visible')
      .selectFile(`cypress/fixtures/${test_data}_example.${test_data}`, {force: true});
  cy.get('[data-testid="data_table"]').wait(5000);
});

Cypress.Commands.add('select_flow', (input, indices) => {
  cy.get(`[data-testid="${input}"]`).click({force: true});
  if (Array.isArray(indices)) {
    indices.forEach((index) => {
      cy.get(`[data-testid="${input}-callout"]`)
        .find(`[data-index="${index}"]`)
        .click({ force: true });
    });
  } else {
    cy.get(`[data-testid="${input}-callout"]`)
      .find(`[data-index="${indices}"]`)
      .click({ force: true });
  }
});

Cypress.Commands.add('turn_panel', () => {
  cy.get('[data-testid="nextbutton"]')
    .should('be.visible')
    .click();
});

Cypress.Commands.add('trainin_test_inputs_flow', () => {
  cy.select_flow('transformation', [0, 1, 2]);
  cy.select_flow('scale', [0, 1, 2]);
  cy.get('[data-testid="inp_amount"]')
    .type('1,2', {force: true});
  cy.get('[data-testid="lstm"]')
    .type('16,32', {force: true});
  for(let n = 0; n < 4; n ++){
    cy.get('[data-testid="tests"] button:nth-child(1)')
      .click({force: true});
  };
});

Cypress.Commands.add('run_flow', () => {
  cy.get('[data-testid="runbutton"').click();
});

